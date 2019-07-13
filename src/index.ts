import {Elm} from './app/Main';
import {rethrow, saveBlob} from './util';
import {Rgba} from './types';
import './polyfills';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.startWorker.subscribe(
    rethrow(handleStartWorker)
);

async function handleStartWorker(color: Rgba) {
    try {
        const {createModPackage} = await import('./worker');
        const blob = await createModPackage(color);
        saveBlob(blob, 'goldvisibility.color.wotmod');
    } finally {
        app.ports.finishedModPackage.send();
    }
}