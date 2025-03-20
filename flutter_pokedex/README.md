# Pokédex Flutter

Una aplicación de Pokédex desarrollada con Flutter que permite explorar y gestionar tu colección de Pokémon.

## Características

- Lista de Pokémon con vista en cuadrícula o lista
- Búsqueda de Pokémon por nombre
- Filtrado por tipo
- Ordenamiento por número o nombre
- Vista detallada de cada Pokémon
- Modo oscuro/claro
- Favoritos con almacenamiento local
- Notificaciones al marcar favoritos
- Carga infinita al hacer scroll
- Botón para mostrar Pokémon aleatorio
- Animaciones y transiciones suaves
- Diseño Material Design 3

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code con extensiones de Flutter

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/flutter_pokedex.git
```

2. Navega al directorio del proyecto:
```bash
cd flutter_pokedex
```

3. Instala las dependencias:
```bash
flutter pub get
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Estructura del Proyecto

```
lib/
  ├── Models/
  │   └── Pokemon.dart
  ├── core/
  │   ├── database_helper.dart
  │   ├── notification_service.dart
  │   └── pokemon_api.dart
  ├── providers/
  │   └── pokemon_provider.dart
  ├── screens/
  │   ├── PokemonList.dart
  │   └── PokemonDetail.dart
  └── main.dart
```

## Tecnologías Utilizadas

- Flutter
- Provider para gestión de estado
- SQLite para almacenamiento local
- Flutter Local Notifications para notificaciones
- HTTP para llamadas a la API
- Material Design 3

## API

La aplicación utiliza la [PokéAPI](https://pokeapi.co/) para obtener los datos de los Pokémon.

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.
