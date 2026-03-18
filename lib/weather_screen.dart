import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';
import 'weather_widgets.dart';

// --- ИМПОРТЫ СЕРВИСОВ ---
import 'services/weather_api.dart';
import 'services/user_manager.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  WeatherInfo? _currentWeather;
  List<ForecastItem> _forecast = [];
  List<FavoriteItem> _favorites = [];

  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _fadeController;
  Timer? _debounce;
  List<dynamic> _citySuggestions = [];
  bool _isSearching = false;

  int _searchesUsed = 0;
  User? _user;

  int get _maxSearches => _user == null ? 5 : 15;
  int get _searchesLeft => _maxSearches - _searchesUsed;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Инициализация данных
    _initData();
  }

  Future<void> _initData() async {
    _favorites = await UserManager.loadFavorites();
    if (mounted) setState(() {});

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (mounted) {
        setState(() => _user = user);
        int limits = await UserManager.loadLimits(user);
        setState(() => _searchesUsed = limits);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cityController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    String? error = await UserManager.signInWithGoogle();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2C),
        title: const Text('Out of requests!', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Free daily limit reached!. Sign up with google to get more requests!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _signInWithGoogle();
            },
            child: const Text('Enter with google', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _searchCities(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      // Вызываем сервис
      final results = await WeatherApi.searchCities(query);
      setState(() {
        _citySuggestions = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _fetchFullWeatherData(String city) async {
    _cityController.clear();
    
    if (_searchesLeft <= 0) {
      if (_user == null) {
        _showLoginDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily limit reached!')),
        );
      }
      return; 
    }

    setState(() {
      _searchesUsed++;
      _isLoading = true;
      _errorMessage = '';
      _citySuggestions = [];
    });
    FocusManager.instance.primaryFocus?.unfocus();

    // Обновляем лимиты через сервис
    await UserManager.incrementLimit(_user, _searchesUsed);

    // Загружаем погоду через сервис
    final data = await WeatherApi.fetchFullWeather(city);

    if (data != null) {
      setState(() {
        _currentWeather = data['weather'];
        _forecast = data['forecast'];
        _isLoading = false;
      });
      _fadeController.reset();
      _fadeController.forward();
    } else {
      setState(() {
        _errorMessage = 'City not found or Connection Error!';
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    if (_currentWeather == null) return;
    setState(() {
      final index = _favorites.indexWhere((item) => item.apiName == _currentWeather!.city);
      if (index >= 0) {
        _favorites.removeAt(index);
      } else {
        _favorites.add(
          FavoriteItem(
            apiName: _currentWeather!.city,
            nickname: _currentWeather!.city,
            lastTemp: _currentWeather!.temperature.toStringAsFixed(0),
          ),
        );
      }
    });
    UserManager.saveFavorites(_favorites);
  }

  void _editFavorite(int index) {
    TextEditingController controller = TextEditingController(text: _favorites[index].nickname);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _favorites[index].nickname = controller.text);
              UserManager.saveFavorites(_favorites);
              Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getLottieAnimation(String iconCode) {
    bool isDay = iconCode.endsWith('d');
    if (iconCode.startsWith('01')) return isDay ? 'assets/clear_day.json' : 'assets/clear_night.json';
    if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) return isDay ? 'assets/cloudy_day.json' : 'assets/cloudy_night.json';
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return isDay ? 'assets/rainy_day.json' : 'assets/rainy_night.json';
    if (iconCode.startsWith('11')) return isDay ? 'assets/stormy_day.json' : 'assets/stormy_night.json';
    if (iconCode.startsWith('13')) return isDay ? 'assets/snow_day.json' : 'assets/snow_night.json';
    return isDay ? 'assets/clear_day.json' : 'assets/clear_night.json';
  }

  // Новый метод для отображения пользователя во всех стейтах
  Widget _buildUserBadge() {
    if (_user == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
            clipBehavior: Clip.antiAlias,
            child: _user!.photoURL != null
                ? Image.network(_user!.photoURL!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 16, color: Colors.white))
                : const Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text('Logged in as ${_user!.displayName ?? 'User'}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  // ================= UI SECTION =================
  @override
  Widget build(BuildContext context) {
    List<Color> bgColors = [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];

    if (_currentWeather != null) {
      bool isDay = _currentWeather!.iconCode.endsWith('d');
      String code = _currentWeather!.iconCode.substring(0, 2);

      if (isDay) {
        if (code == '01') {
          bgColors = [const Color(0xFF4A90E2), const Color(0xFF50E3C2)];
        } else if (code == '02' || code == '03' || code == '04') bgColors = [const Color(0xFF8BA4B1), const Color(0xFFC4D3DF)];
        else if (code == '09' || code == '10') bgColors = [const Color(0xFF4A5568), const Color(0xFF718096)];
        else if (code == '11') bgColors = [const Color(0xFF2D3748), const Color(0xFF4A5568)];
        else if (code == '13') bgColors = [const Color(0xFF94A3B8), const Color(0xFFE2E8F0)];
      } else {
        if (code == '01') {
          bgColors = [const Color(0xFF0F2027), const Color(0xFF203A43)];
        } else if (code == '02' || code == '03' || code == '04') bgColors = [const Color(0xFF141E30), const Color(0xFF243B55)];
        else if (code == '09' || code == '10') bgColors = [const Color(0xFF0F2027), const Color(0xFF203A43)];
        else if (code == '11') bgColors = [const Color(0xFF141E30), const Color(0xFF243B55)];
        else if (code == '13') bgColors = [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: FavoritesDrawer(
        favorites: _favorites,
        onEdit: _editFavorite,
        onDelete: (index) {
          setState(() => _favorites.removeAt(index));
          UserManager.saveFavorites(_favorites);
        },
        onSelect: _fetchFullWeatherData,
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bgColors),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white)))
                    : _currentWeather == null
                    ? _buildEmptyState()
                    : _buildMainContent(),
              ),
              _buildUserBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/clear_day.json', height: 200),
            const SizedBox(height: 20),
            const Text('Welcome to Weather Pro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Enter a city name in the search bar above to get the latest weather forecast and save it to your favorites.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            if (_user == null)
              TextButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Sign in to get 15 daily requests', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search City... ($_searchesLeft requests left)',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    suffixIcon: _isSearching
                        ? const Padding(padding: EdgeInsets.all(10.0), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                        : _cityController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () { _cityController.clear(); setState(() => _citySuggestions = []); })
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {});
                    _searchCities(val);
                  },
                  onSubmitted: _fetchFullWeatherData,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _fetchFullWeatherData(_cityController.text),
              ),
            ],
          ),
        ),
        if (_citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E).withOpacity(0.95), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _citySuggestions.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final city = _citySuggestions[index];
                return ListTile(
                  title: Text(city['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(city['state'].toString().isNotEmpty ? '${city['state']}, ${city['country']}' : city['country'], style: const TextStyle(color: Colors.grey)),
                  onTap: () { _cityController.text = city['name']; _fetchFullWeatherData(city['name']); },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent() {
    DateTime cityLocalTime = DateTime.now().toUtc().add(Duration(seconds: _currentWeather!.timezone));
    String formattedDate = DateFormat('EEEE, d MMMM').format(cityLocalTime);
    String formattedTime = DateFormat('HH:mm').format(cityLocalTime);

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(_currentWeather!.city, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('•', style: TextStyle(color: Colors.white70))),
                Text(formattedTime, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: Lottie.asset(_getLottieAnimation(_currentWeather!.iconCode))),
            Text('${_currentWeather!.temperature.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 90, color: Colors.white, fontWeight: FontWeight.w200)),
            Text(_currentWeather!.description.toUpperCase(), style: const TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 2)),
            IconButton(
              icon: Icon(_favorites.any((e) => e.apiName == _currentWeather!.city) ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 30),
              onPressed: _toggleFavorite,
            ),
            const SizedBox(height: 30),
            HourlyForecastView(forecast: _forecast),
            WeatherGridDetails(weather: _currentWeather!),
            // Оставил только кнопку входа для неавторизованных
            if (_user == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login, color: Colors.white70),
                  label: const Text('Sign in to sync & get more requests', style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline, decorationColor: Colors.white70)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}