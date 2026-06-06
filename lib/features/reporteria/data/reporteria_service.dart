import '../../historial/data/historial_model.dart';
import '../../historial/data/historial_repository.dart';
import '../../perros/data/perro_model.dart';
import '../../perros/data/perros_repository.dart';
import '../../propietarios/data/propietario_model.dart';
import '../../propietarios/data/propietarios_repository.dart';

class ReporteriaSnapshot {
  const ReporteriaSnapshot({
    required this.totalPropietarios,
    required this.totalPerros,
    required this.totalHistoriales,
    required this.promedioEdadPerros,
    required this.ultimosHistoriales,
    required this.perrosPorRaza,
    required this.reportePorPropietario,
  });

  final int totalPropietarios;
  final int totalPerros;
  final int totalHistoriales;
  final double promedioEdadPerros;
  final List<HistorialRecienteItem> ultimosHistoriales;
  final List<RazaCountItem> perrosPorRaza;
  final List<PropietarioReporteItem> reportePorPropietario;
}

class HistorialRecienteItem {
  const HistorialRecienteItem({
    required this.perroId,
    required this.perroNombre,
    required this.fecha,
    required this.diagnostico,
  });

  final String perroId;
  final String perroNombre;
  final DateTime fecha;
  final String diagnostico;
}

class RazaCountItem {
  const RazaCountItem({required this.raza, required this.total});

  final String raza;
  final int total;
}

class PropietarioReporteItem {
  const PropietarioReporteItem({
    required this.propietario,
    required this.perros,
    required this.totalEntradas,
  });

  final PropietarioModel propietario;
  final List<PerroVisitaItem> perros;
  final int totalEntradas;
}

class PerroVisitaItem {
  const PerroVisitaItem({
    required this.perro,
    required this.totalEntradas,
    required this.ultimaVisita,
  });

  final PerroModel perro;
  final int totalEntradas;
  final DateTime? ultimaVisita;
}

class ReporteriaService {
  ReporteriaService({
    PropietariosRepository? propietariosRepository,
    PerrosRepository? perrosRepository,
    HistorialRepository? historialRepository,
  }) : _propietariosRepository =
           propietariosRepository ?? PropietariosRepository(),
       _perrosRepository = perrosRepository ?? PerrosRepository(),
       _historialRepository = historialRepository ?? HistorialRepository();

  final PropietariosRepository _propietariosRepository;
  final PerrosRepository _perrosRepository;
  final HistorialRepository _historialRepository;

  Future<ReporteriaSnapshot> cargarResumen() async {
    final propietarios = await _propietariosRepository.obtenerTodos();
    final perros = await _perrosRepository.obtenerTodos();

    final historialPorPerro = <String, List<HistorialModel>>{};

    if (perros.isNotEmpty) {
      final historialEntries = await Future.wait(
        perros.map((perro) async {
          final historial = await _historialRepository.obtenerPorPerro(
            perro.id,
          );
          historial.sort((a, b) => b.fecha.compareTo(a.fecha));
          return MapEntry(perro.id, historial);
        }),
      );

      for (final entry in historialEntries) {
        historialPorPerro[entry.key] = entry.value;
      }
    }

    final totalHistoriales = historialPorPerro.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    final promedioEdadPerros = perros.isEmpty
        ? 0
        : perros.fold<int>(0, (sum, item) => sum + item.edad) / perros.length;

    final ultimosHistoriales = _buildUltimosHistoriales(
      perros: perros,
      historialPorPerro: historialPorPerro,
    );

    final perrosPorRaza = _buildPerrosPorRaza(perros);

    final reportePorPropietario = _buildReportePorPropietario(
      propietarios: propietarios,
      perros: perros,
      historialPorPerro: historialPorPerro,
    );

    return ReporteriaSnapshot(
      totalPropietarios: propietarios.length,
      totalPerros: perros.length,
      totalHistoriales: totalHistoriales,
      promedioEdadPerros: promedioEdadPerros.toDouble(),
      ultimosHistoriales: ultimosHistoriales,
      perrosPorRaza: perrosPorRaza,
      reportePorPropietario: reportePorPropietario,
    );
  }

  List<HistorialRecienteItem> _buildUltimosHistoriales({
    required List<PerroModel> perros,
    required Map<String, List<HistorialModel>> historialPorPerro,
  }) {
    final perrosById = {for (final p in perros) p.id: p};

    final items = <HistorialRecienteItem>[];

    for (final entry in historialPorPerro.entries) {
      final perro = perrosById[entry.key];
      final perroNombre = perro?.nombre ?? 'Perro';

      for (final historial in entry.value) {
        items.add(
          HistorialRecienteItem(
            perroId: entry.key,
            perroNombre: perroNombre,
            fecha: historial.fecha,
            diagnostico: historial.diagnostico,
          ),
        );
      }
    }

    items.sort((a, b) => b.fecha.compareTo(a.fecha));
    return items.take(5).toList();
  }

  List<RazaCountItem> _buildPerrosPorRaza(List<PerroModel> perros) {
    final map = <String, int>{};

    for (final perro in perros) {
      final raza = perro.raza.trim().isEmpty ? 'Sin raza' : perro.raza.trim();
      map[raza] = (map[raza] ?? 0) + 1;
    }

    final items = map.entries
        .map((entry) => RazaCountItem(raza: entry.key, total: entry.value))
        .toList();

    items.sort((a, b) {
      final byTotal = b.total.compareTo(a.total);
      if (byTotal != 0) {
        return byTotal;
      }
      return a.raza.toLowerCase().compareTo(b.raza.toLowerCase());
    });

    return items;
  }

  List<PropietarioReporteItem> _buildReportePorPropietario({
    required List<PropietarioModel> propietarios,
    required List<PerroModel> perros,
    required Map<String, List<HistorialModel>> historialPorPerro,
  }) {
    final perrosPorPropietario = <String, List<PerroModel>>{};

    for (final perro in perros) {
      perrosPorPropietario
          .putIfAbsent(perro.propietarioId, () => [])
          .add(perro);
    }

    final result = <PropietarioReporteItem>[];

    for (final propietario in propietarios) {
      final perrosDelProp = perrosPorPropietario[propietario.id] ?? const [];

      final perroItems = perrosDelProp.map((perro) {
        final historial =
            historialPorPerro[perro.id] ?? const <HistorialModel>[];
        return PerroVisitaItem(
          perro: perro,
          totalEntradas: historial.length,
          ultimaVisita: historial.isEmpty ? null : historial.first.fecha,
        );
      }).toList();

      perroItems.sort(
        (a, b) => a.perro.nombre.toLowerCase().compareTo(
          b.perro.nombre.toLowerCase(),
        ),
      );

      final totalEntradas = perroItems.fold<int>(
        0,
        (sum, item) => sum + item.totalEntradas,
      );

      result.add(
        PropietarioReporteItem(
          propietario: propietario,
          perros: perroItems,
          totalEntradas: totalEntradas,
        ),
      );
    }

    result.sort(
      (a, b) => a.propietario.nombre.toLowerCase().compareTo(
        b.propietario.nombre.toLowerCase(),
      ),
    );

    return result;
  }
}
