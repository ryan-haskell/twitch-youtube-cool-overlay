const { WebSocketServer } = require('ws')
const { LiveChat } = require('youtube-chat')
const tmi = require('tmi.js');

/**
 * App-specific configuration we might want to
 * tweak later.
 */
const config = {
  port: 3001
}


/**
 * Runs with the application starts
 */
async function main() {
  const server = new WebSocketServer({ port: config.port })

  console.log('SERVER STARTING...')
  server.on('connection', function connection(ws) {
    ws.on('error', console.error)
    ws.on('message', function message(raw) {
      try {
        let data = JSON.parse(raw)
        if (data && data.handle) {
          listenForTwitchChatMessages({
            handle: data.handle,
            onChatItem: (chatItem) => ws.send(JSON.stringify(chatItem))
          })
        }
      } catch (reason) {
        console.error('ERR: ', reason)
      }
    })
  })
}


function listenForTwitchChatMessages({ handle, onChatItem }) {
  const client = new tmi.Client({
    channels: [handle]
  });

  client.connect();

  client.on('message', (channel, tags, message, self) => {
    let id = tags.id || String(Math.random() * Number.MAX_SAFE_INTEGER)
    let data = {
      id,
      author: tags['display-name'],
      message
    }

    console.log(data)

    onChatItem(data)
  });
}


/** 
 * Listens for chat on the specified channel
 * @typedef {import('youtube-chat/dist/types/data').ChatItem} ChatItem
 * @param {{ handle: string, onChatItem: (chatItem : ChatItem) => unknown }} options 
 * @returns {Promise<boolean>}
*/
function listenForYouTubeChatMessages({ handle, onChatItem }) {
  return new Promise(async (resolve, reject) => {
    try {
      let liveChat = new LiveChat({ handle })
      liveChat.on("chat", (chatItem) => onChatItem(chatItem))
      liveChat.on("error", (err) => reject(err))

      let ok = await liveChat.start()

      if (ok) { resolve(true) }
    } catch (reason) {
      reject(reason)
    }
  })
}

// Run the main program
main()
  .catch(console.error)