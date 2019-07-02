import {Elm} from './app/Main';
import {Rgba} from './types';
import {rethrowError, saveBlob} from "./util";

// Fail fast instead of making the app unusable
if (!self.WebAssembly) {
    throw new Error("Browser not supported");
}

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.startWorker.subscribe(color => {
    return createAndSaveModPackage(color)
        .then(() => app.ports.finishedModPackage.send())
        .catch(rethrowError)
});

async function createAndSaveModPackage(color: Rgba) {
    const { createModPackage } = await import('./worker');
    const blob = await createModPackage(color);
    saveBlob(blob, 'goldvisibility.color.wotmod');
}