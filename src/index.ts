import {Elm} from './app/Main';
import {Rgba} from './types';

import './styles.css';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.startWorker.subscribe(color => createModPackage(color).catch(rethrowError));

async function createModPackage(color: Rgba) {
    const { createModPackage } = await import('./worker');
    const buffer = await createModPackage(color);
    const blob = new Blob([buffer]);
    saveBlob(blob, 'goldvisibility.color.wotmod');
    app.ports.finishedModPackage.send();
}

function saveBlob(blob: Blob, fileName: string) {
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

export function rethrowError(e: Error) {
    setTimeout(() => {
        // throw error in new event loop cycle to escape promise and trigger global error hook
        throw e;
    });
    return Promise.reject(e);
}