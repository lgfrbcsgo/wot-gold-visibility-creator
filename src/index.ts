import {run} from './worker';
import {Elm} from './elm/Main';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.startCreator.subscribe(color => {
    run(color).then(buffer => {
        const blob = new Blob([new Uint8Array(buffer)]);
        app.ports.getPackage.send({
            color,
            blobUrl: URL.createObjectURL(blob)
        });
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
});