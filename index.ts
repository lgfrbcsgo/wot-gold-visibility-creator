import {run} from './worker';

import {Elm} from './elm/Main';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

app.ports.run.subscribe(color => {
    run(color).then(buffer => {
        const blob = new Blob([new Uint8Array(buffer)]);
        saveFile(blob, 'test.wotmod');
    });
});


// https://stackoverflow.com/questions/19327749
function saveFile(blob: Blob, filename: string) {
    if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, filename);
    } else {
        const a = document.createElement('a');
        document.body.appendChild(a);
        const url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = filename;
        a.click();
        setTimeout(() => {
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        }, 0)
    }
}