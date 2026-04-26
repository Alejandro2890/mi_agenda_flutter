import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'models/event_model.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const MyApp());
}

Future<void> _initNotifications() async {
  final notifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );
  await notifications.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isMuted = prefs.getBool('muted') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('muted', _isMuted);
  }

  void _playSound(String sound) async {
    if (_isMuted) return;
    final player = AudioPlayer();
    await player.play(AssetSource(sound));
    await Future.delayed(const Duration(seconds: 1));
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Agenda',
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        isMuted: _isMuted,
        onThemeToggle: (value) {
          setState(() {
            _isDarkMode = value;
            _saveSettings();
            if (!_isMuted) _playSound('click.mp3');
          });
        },
        onMuteToggle: (value) {
          setState(() {
            _isMuted = value;
            _saveSettings();
          });
        },
      ),
    );
  }
}

// Colores personalizados - Verde manzana más suave
const Color verdeManzana = Color(
  0xFFA8E6A3,
); // Verde manzana pastel (más suave)
const Color amarilloCalido = Color(0xFFFFD166); // Amarillo cálido para acentos
const Color lilaClaro = Color(0xFFF0E6FF); // Lila clarito para fondo
const Color lilaMedio = Color(0xFFD4B8FF); // Lila para detalles
const Color violetaSuave = Color(0xFFB87CFF); // Violeta suave para acentos

// Tema claro con verde manzana suave, amarillo y lila de fondo
final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: lilaClaro,
  colorScheme: const ColorScheme.light(
    primary: verdeManzana,
    secondary: amarilloCalido,
    tertiary: lilaMedio,
    surface: Colors.white,
    onPrimary: Colors.black87,
    onSecondary: Colors.black87,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    foregroundColor: Colors.black87,
    backgroundColor: verdeManzana,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: verdeManzana,
    foregroundColor: Colors.black87,
  ),
  cardTheme: CardTheme(
    elevation: 4,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: amarilloCalido.withOpacity(0.6), width: 2.5),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: verdeManzana,
    unselectedItemColor: Color(0xFF999999),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: amarilloCalido.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: amarilloCalido, width: 2.5),
    ),
  ),
);

// Tema oscuro adaptado
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
  colorScheme: const ColorScheme.dark(
    primary: verdeManzana,
    secondary: amarilloCalido,
    tertiary: lilaMedio,
    surface: Color(0xFF16213E),
    onPrimary: Colors.black87,
    onSecondary: Colors.black87,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    foregroundColor: Colors.black87,
    backgroundColor: verdeManzana,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: verdeManzana,
    foregroundColor: Colors.black87,
  ),
  cardTheme: CardTheme(
    elevation: 4,
    color: const Color(0xFF1E1E2F),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: amarilloCalido.withOpacity(0.4), width: 2.5),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: verdeManzana,
    unselectedItemColor: Color(0xFF666666),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: amarilloCalido.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: amarilloCalido, width: 2.5),
    ),
  ),
);

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool isMuted;
  final Function(bool) onThemeToggle;
  final Function(bool) onMuteToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.isMuted,
    required this.onThemeToggle,
    required this.onMuteToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<EventModel>> _events = {};
  final DatabaseHelper _db = DatabaseHelper();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _db.getEvents();
    final Map<DateTime, List<EventModel>> grouped = {};
    for (var event in events) {
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }
    setState(() {
      _events = grouped;
    });
  }

  void _playSound(String sound) {
    if (widget.isMuted) return;
    final player = AudioPlayer();
    player.play(AssetSource(sound));
    Future.delayed(const Duration(seconds: 1), () => player.dispose());
  }

  Future<void> _addEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    );
    if (result == true) {
      await _loadEvents();
      _playSound('save.mp3');
    }
  }

  Future<void> _deleteEvent(EventModel event) async {
    await _db.deleteEvent(event.id!);
    await _loadEvents();
    _playSound('delete.mp3');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
    }
  }

  void _showEventDetail(EventModel event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: amarilloCalido, width: 2.5),
            ),
            title: Row(
              children: [
                Icon(Icons.event, color: verdeManzana),
                const SizedBox(width: 8),
                Expanded(child: Text(event.title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imagePath != null &&
                    File(event.imagePath!).existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(event.imagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(event.description),
                const SizedBox(height: 8),
                Text('📅 ${DateFormat('dd/MM/yyyy').format(event.date)}'),
                Text('⏰ ${event.time.format(context)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteEvent(event);
                },
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  Widget _buildEventsForDay(DateTime day) {
    final events = _events[DateTime(day.year, day.month, day.day)] ?? [];
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Color(0xFF999999)),
            SizedBox(height: 16),
            Text('No hay eventos para este día'),
            Text('Presioná el botón + para agregar'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading:
                event.imagePath != null && File(event.imagePath!).existsSync()
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(event.imagePath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: lilaClaro,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: amarilloCalido, width: 2.5),
                      ),
                      child: Icon(Icons.event, color: violetaSuave),
                    ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 4),
                Text(
                  '${event.time.format(context)} hs',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteEvent(event),
            ),
            onTap: () => _showEventDetail(event),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _playSound('click.mp3');
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            // Calendario con borde amarillo
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: amarilloCalido, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    _playSound('click.mp3');
                  },
                  eventLoader: (day) => _events[day] ?? [],
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: verdeManzana.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: amarilloCalido, width: 1.5),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: verdeManzana,
                      shape: BoxShape.circle,
                      border: Border.all(color: amarilloCalido, width: 2),
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  locale: 'es_ES',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildEventsForDay(_selectedDay)),
          ],
        );
      case 1:
        return _buildEventsListScreen();
      case 2:
        return _buildSettingsScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildEventsListScreen() {
    return FutureBuilder<List<EventModel>>(
      future: _db.getEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 64, color: Color(0xFF999999)),
                SizedBox(height: 16),
                Text('No hay eventos guardados'),
              ],
            ),
          );
        }
        final sortedEvents = List<EventModel>.from(events)
          ..sort((a, b) => a.date.compareTo(b.date));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedEvents.length,
          itemBuilder: (context, index) {
            final event = sortedEvents[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading:
                    event.imagePath != null &&
                            File(event.imagePath!).existsSync()
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(event.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: lilaClaro,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: amarilloCalido,
                              width: 2.5,
                            ),
                          ),
                          child: Icon(Icons.event, color: violetaSuave),
                        ),
                title: Text(event.title),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(event.date)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showEventDetail(event),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Modo nocturno'),
            subtitle: const Text('Oscurece la interfaz'),
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
            secondary: Icon(Icons.dark_mode, color: violetaSuave),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Modo mudo'),
            subtitle: const Text('Desactiva los sonidos'),
            value: widget.isMuted,
            onChanged: widget.onMuteToggle,
            secondary: Icon(Icons.volume_off, color: violetaSuave),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.info, size: 48, color: verdeManzana),
                const SizedBox(height: 12),
                const Text(
                  'Mi Agenda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Versión 1.0.0'),
                const SizedBox(height: 8),
                Text(
                  '© 2026 - Tu agenda personal',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _imagePath;
  bool _hasNotification = true;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Fecha',
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Seleccionar hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (time != null && mounted) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final event = EventModel(
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      time: _selectedTime,
      imagePath: _imagePath,
      hasNotification: _hasNotification,
    );

    await DatabaseHelper().insertEvent(event);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo evento'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título*',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: amarilloCalido,
                              width: 2.5,
                            ),
                          ),
                        ),
                        validator:
                            (v) => v!.isEmpty ? 'Ingresá un título' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: amarilloCalido,
                              width: 2.5,
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: violetaSuave,
                        ),
                        title: const Text('Fecha'),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                        onTap: _selectDate,
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.access_time, color: violetaSuave),
                        title: const Text('Hora'),
                        subtitle: Text(_selectedTime.format(context)),
                        onTap: _selectTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagen (opcional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galería'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verdeManzana,
                                foregroundColor: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Cámara'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verdeManzana,
                                foregroundColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_imagePath != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _imagePath = null),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Eliminar imagen'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Activar recordatorio'),
                  subtitle: const Text(
                    'Recibirás una notificación a la hora del evento',
                  ),
                  value: _hasNotification,
                  onChanged: (v) => setState(() => _hasNotification = v),
                  secondary: Icon(
                    Icons.notifications_active,
                    color: violetaSuave,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCCCCC),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveEvent,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeManzana,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
