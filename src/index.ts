import {Elm} from './app/Main';
import {IRgba} from './common';

import './styles.css';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.revokeBlob.subscribe(revokeBlob);
app.ports.runWorker.subscribe(color => createModPackage(color).catch(rethrowError));
app.ports.saveBlob.subscribe(({ blobUrl, fileName }) => saveBlob(blobUrl, fileName));

function revokeBlob(blobUrl: string) {
    URL.revokeObjectURL(blobUrl);
}

async function createModPackage(color: IRgba) {
    const { createModPackage } = await import('./worker');
    const buffer = await createModPackage(color);
    const blob = new Blob([buffer]);
    app.ports.getPackage.send({
        color,
        blobUrl: URL.createObjectURL(blob)
    });
}

function saveBlob(blobUrl: string, fileName: string) {
    const a = document.createElement('a');
    document.body.appendChild(a);
    a.href = blobUrl;
    a.download = fileName;
    a.click();
    setTimeout(() => {
        document.body.removeChild(a);
    });
}

export function rethrowError(e: Error) {
    setTimeout(() => {
        // throw error in new event loop cycle to escape promise and trigger global error hook
        throw e;
    });
    return Promise.reject(e);
}