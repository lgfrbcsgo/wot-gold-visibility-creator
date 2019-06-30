import {Elm} from './app/Main';
import {Rgba} from './types';

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
    const buffer = await createModPackage(color);
    const blob = new Blob([buffer]);
    saveBlob(blob, 'goldvisibility.color.wotmod');
}

function saveBlob(blob: Blob, fileName: string) {
    if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, fileName);
    }
    else {
        const blobUrl = URL.createObjectURL(blob);
        const a = document.createElement('a');
        document.body.appendChild(a);
        a.href = blobUrl;
        a.download = fileName;
        a.click();
        setTimeout(() => {
            document.body.removeChild(a);
            URL.revokeObjectURL(blobUrl);
        });
    }
}

// Throws the error inside a setTimout to trigger the global error hook from the context of a Promise
export function rethrowError(e: Error) {
    setTimeout(() => {
        throw e;
    });
    return Promise.reject(e);
}