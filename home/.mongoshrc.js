// ~/.mongoshrc.js -- mongosh startup config (the ~/.psqlrc equivalent).
// Loaded before the first prompt; skip it with `mongosh --norc`.

// ---- settings ------------------------------------------------------------
config.set('inspectDepth', 10); // nested object depth in output (default 6)
config.set('displayBatchSize', 20); // docs per cursor iteration (default 20)
config.set('showStackTraces', true); // full stack traces on errors
config.set('historyLength', 10000); // matches HISTSIZE in ~/.psqlrc
config.set('redactHistory', 'remove-redact'); // scrub auth/connect calls, paths, URLs from history
config.set('editor', process.env.EDITOR || 'vim');
config.set('enableTelemetry', false); // no usage telemetry
config.set('updateURL', ''); // skip the startup update check

// ---- prompt: green db, yellow host --------------------------------------
(function () {
  const hostSymbol = Symbol('host');
  const green = (s) => `\x1b[1;32m${s}\x1b[0m`;
  const yellow = (s) => `\x1b[1;33m${s}\x1b[0m`;

  const hostName = () => {
    if (db[hostSymbol] === undefined) {
      try {
        db[hostSymbol] = db.serverStatus().host;
      } catch (e) {
        db[hostSymbol] = ''; // serverStatus needs clusterMonitor; show db only
      }
    }
    return db[hostSymbol];
  };

  prompt = () => {
    try {
      const host = hostName();
      return host ? `${green(db.getName())}@${yellow(host)}> ` : `${green(db.getName())}> `;
    } catch (e) {
      return '> '; // no connection yet
    }
  };
})();

// ---- helpers ------------------------------------------------------------
/** Sorted collection names in the current database. */
cols = () => db.getCollectionNames().sort();

/** Sorted database names. */
dbs = () =>
  db
    .adminCommand({ listDatabases: 1, nameOnly: true })
    .databases.map((d) => d.name)
    .sort();

/** Storage per collection, largest first. */
sizes = () =>
  db
    .getCollectionNames()
    .map((name) => {
      const s = db.getCollection(name).stats();
      return {
        collection: name,
        docs: s.count,
        sizeMB: +(s.size / 1048576).toFixed(1),
        indexMB: +(s.totalIndexSize / 1048576).toFixed(1),
      };
    })
    .sort((a, b) => b.sizeMB - a.sizeMB);

/** Time an operation: `await t(() => db.c.find({}).toArray())`. */
t = async (fn) => {
  const start = Date.now();
  try {
    return await fn();
  } finally {
    print(`took ${Date.now() - start} ms`);
  }
};

/** Date literal helper: `db.c.find({ ts: { $gte: d('2025-01-01') } })`. */
d = (s) => new Date(s);

// vim: set ft=javascript:
