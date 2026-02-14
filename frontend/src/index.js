import { Elm } from './Main.elm';

const app = Elm.Main.init({ node: document.getElementById('app') });

// WebSocket connection
let socket = null;
let channel = null;

// Simulated speech for POC (in production, would come from Web Audio API)
let simulatedSpeech = "I really enjoy hiking in the mountains. The fresh air and beautiful scenery make me feel peaceful and connected to nature. I try to go at least once a month.";

function connectToChannel() {
  socket = new WebSocket('ws://localhost:4000/socket/websocket');

  socket.onopen = function () {
    console.log('[WebSocket] Connected to server');
    
    // Join the channel
    const joinMsg = {
      topic: 'session:user_session',
      event: 'phx_join',
      payload: {},
      ref: '1'
    };
    socket.send(JSON.stringify(joinMsg));
    channel = 'session:user_session';
  };

  socket.onmessage = function (event) {
    try {
      const msg = JSON.parse(event.data);
      
      // Check if it's a response to our finished_speaking message
      if (msg.topic === 'session:user_session' && msg.event === 'phx_reply') {
        if (msg.payload && msg.payload.response) {
          // Send the detailed feedback to Elm
          app.ports.recv.send(msg.payload.response);
        }
      }
    } catch (e) {
      console.error('[WebSocket] Error parsing message:', e);
    }
  };

  socket.onerror = function (error) {
    console.error('[WebSocket] Error:', error);
  };

  socket.onclose = function () {
    console.log('[WebSocket] Disconnected from server');
  };
}

// Connect when app is ready
setTimeout(connectToChannel, 100);

// Handle outgoing messages from Elm
app.ports.send.subscribe(function (msg) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    // If it's a finished_speaking message, add the simulated speech
    let payload = msg.payload;
    if (msg.event === 'finished_speaking') {
      payload = { speech: simulatedSpeech };
    }

    const message = {
      topic: msg.topic,
      event: msg.event,
      payload: payload,
      ref: Math.random().toString().substring(2)
    };
    
    console.log('[WebSocket] Sending:', message);
    socket.send(JSON.stringify(message));
  } else {
    console.warn('[WebSocket] Connection not ready, message not sent');
  }
});
