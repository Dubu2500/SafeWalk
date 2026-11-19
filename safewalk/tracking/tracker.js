import {initializeApp} from 'https://www.gstatic.com/firebasejs/12.6.0/firebase-app.js';
import {getFirestore, doc, onSnapshot} from 'https://www.gstatic.com/firebasejs/12.6.0/firebase-firestore.js';

const id = location.hash.slice(1);
const state = document.querySelector('#state');
const coordinates = document.querySelector('#coordinates');
const updated = document.querySelector('#updated');
const map = document.querySelector('#map');
const card = document.querySelector('#card');
let stop = () => {}, expiryTimer, staleTimer, audioContext;
let lastAlert = false;
function clearPosition() { map.hidden = true; map.removeAttribute('href'); coordinates.textContent = ''; }
function end(message) { stop(); clearTimeout(expiryTimer); clearInterval(staleTimer); clearPosition(); state.textContent = message; }
document.querySelector('#sound').onclick = async () => {
  try { audioContext = new AudioContext(); await audioContext.resume(); document.querySelector('#sound').textContent = 'Sonido activado'; }
  catch { document.querySelector('#sound').textContent = 'Sonido no disponible'; }
};
function beep() {
  if (!audioContext) return;
  const oscillator = audioContext.createOscillator();
  const gain = audioContext.createGain();
  oscillator.frequency.value = 740; gain.gain.value = 0.15;
  oscillator.connect(gain); gain.connect(audioContext.destination);
  oscillator.start(); oscillator.stop(audioContext.currentTime + 0.8);
}
async function start() {
  if (!/^[A-Za-z0-9_-]{43}$/.test(id)) { end('Enlace inválido. Solicita un nuevo enlace de SafeWalk.'); return; }
  try {
    // Firebase Hosting supplies the Web app configuration; no secret key in this page.
    const response = await fetch('/__/firebase/init.json');
    if (!response.ok) throw new Error('hosting-config');
    const db = getFirestore(initializeApp(await response.json()));
    stop = onSnapshot(doc(db, 'liveTrips', id), snapshot => {
      if (!snapshot.exists()) { end('El trayecto terminó o el enlace se ha revocado.'); return; }
      const data = snapshot.data();
      clearTimeout(expiryTimer); clearInterval(staleTimer);
      const expires = data.expiresAt?.toMillis() ?? 0;
      if (Date.now() >= expires) { end('El enlace ha caducado.'); return; }
      expiryTimer = setTimeout(() => end('El enlace ha caducado.'), expires - Date.now());
      if (data.status === 'ended') { end('El trayecto ha terminado. La ubicación ya no se comparte.'); return; }
      const latitude = data.latitude, longitude = data.longitude;
      if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) { end('Ubicación no disponible.'); return; }
      coordinates.textContent = `${latitude.toFixed(6)}, ${longitude.toFixed(6)}`;
      map.href = `https://maps.google.com/?q=${latitude},${longitude}`; map.hidden = false;
      card.classList.toggle('alert', data.alert === true);
      state.textContent = data.alert ? '⚠ Alerta: no respondió al aviso de desvío o pidió ayuda. Intenta contactarle.' : 'Trayecto activo · Recibiendo ubicación';
      if (data.alert && !lastAlert) beep();
      lastAlert = data.alert === true;
      const lastUpdate = data.updatedAt?.toMillis();
      const showAge = () => {
        const age = lastUpdate ? Math.max(0, Math.floor((Date.now() - lastUpdate) / 1000)) : null;
        updated.textContent = age === null ? 'Esperando confirmación del servidor…' : age > 30 ? `Sin ubicación nueva desde hace ${age} segundos. Puede estar sin conexión o con la app cerrada.` : `Última actualización hace ${age} segundos.`;
      };
      showAge(); staleTimer = setInterval(showAge, 1000);
    }, () => end('El trayecto terminó, el enlace caducó o no hay conexión. Solicita un enlace nuevo si hace falta.'));
  } catch { end('No se pudo conectar. Revisa la conexión o solicita un enlace nuevo.'); }
}
window.addEventListener('pagehide', () => { stop(); clearTimeout(expiryTimer); clearInterval(staleTimer); });
start();
