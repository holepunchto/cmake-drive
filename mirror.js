const process = require('process')
const path = require('path')
const Corestore = require('corestore')
const Hyperswarm = require('hyperswarm')
const Hyperdrive = require('hyperdrive')
const Localdrive = require('localdrive')
const id = require('hypercore-id-encoding')

const [
  storage,
  cwd,
  prefix,
  checkout,
  source,
  destination
] = process.argv.slice(2)

const symbols = {
  add: '+',
  remove: '-',
  change: '~'
}

mirror(source, destination)

async function mirror (source, destination) {
  const store = new Corestore(path.resolve(cwd, storage))
  const swarm = new Hyperswarm().on('connection', (socket) => store.replicate(socket))

  source = await open(source, { store, swarm, cwd })
  destination = await open(destination, { store, swarm, cwd })

  if (checkout) source = source.checkout(+checkout)

  for await (const entry of source.mirror(destination, { prefix, prune: false })) {
    console.log(`${symbols[entry.op]} ${entry.key}`)
  }

  await swarm.destroy()
}

async function open (key, opts = {}) {
  const { store, swarm, cwd } = opts

  if (!isKey(key)) return new Localdrive(path.resolve(cwd, key))

  const drive = new Hyperdrive(store, id.decode(key))
  await drive.ready()

  if (swarm) {
    swarm.join(drive.discoveryKey)

    const done = store.findingPeers()

    swarm
      .flush()
      .then(done)

    await drive.core.update()
  }

  return drive
}

function isKey (key) {
  return (key.length === 52 || key.length === 64) && key.indexOf('/') === -1 && key.indexOf('\\') === -1 && key.indexOf('.') === -1
}
