const browserSync = require('browser-sync').create();

browserSync.init({
    files: ['static_compiled/**/*', '**/templates/**/*'],
    proxy: 'http://localhost:8000',
    open: false,
    notify: false,
});
