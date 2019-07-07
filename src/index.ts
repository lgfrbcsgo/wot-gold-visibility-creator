import {Elm} from './app/Main';
import {rethrow, saveBlob} from './util';
import './polyfills';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.startWorker.subscribe(rethrow(async color => {
    try {
        const {createModPackage} = await import('./worker');
        const blob = await createModPackage(color);
        saveBlob(blob, 'goldvisibility.color.wotmod');
    } finally {
        app.ports.finishedModPackage.send();
    }
}));