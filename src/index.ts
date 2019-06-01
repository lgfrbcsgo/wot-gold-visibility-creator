import {run} from './worker';
import {Elm} from './elm/Main';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.runWorker.subscribe(async color => {
    const buffer = await run(color);
    const blob = new Blob([buffer]);
    app.ports.getPackage.send({
        color,
        blobUrl: URL.createObjectURL(blob)
    });
});

app.ports.revokeBlob.subscribe(blobUrl => {
    URL.revokeObjectURL(blobUrl);
});

app.ports.saveBlob.subscribe(({ blobUrl, fileName }) => {
    const a = document.createElement('a');
    document.body.appendChild(a);
    a.href = blobUrl;
    a.download = fileName;
    a.click();
    setTimeout(() => {
        document.body.removeChild(a);
    });
});