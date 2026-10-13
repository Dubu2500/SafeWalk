import '../models/destination.dart';

// Temporary local data until profiles and saved destinations are connected.
const userName = 'Rubén';
const trustedContactName = 'María';

const destinations = [
  Destination(
    id: 'home',
    title: 'Casa',
    subtitle: 'Calle Serrano 42',
    emoji: '🏠',
    kind: DestinationKind.home,
  ),
  Destination(
    id: 'map',
    title: 'Elegir destino',
    subtitle: 'Buscar en el mapa',
    emoji: '📍',
    kind: DestinationKind.map,
  ),
  Destination(
    id: 'recent',
    title: 'Destino reciente',
    subtitle: 'Centro Comercial Moda',
    emoji: '🕘',
    kind: DestinationKind.recent,
  ),
];
