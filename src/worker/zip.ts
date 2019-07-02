const {zip}: any = require('../../lib/zip.js/WebContent/zip.js');
const zipWorkerUrl: string = require('file-loader!../../lib/zip.js/WebContent/z-worker.js');

zip.workerScripts = {
    deflater: [zipWorkerUrl]
};

export interface ZipWriter {
    add(fileName: string, content: Blob): Promise<void>;
    close(): Promise<Blob>;
}

export async function createZipWriter(): Promise<ZipWriter> {
    const writer: any = await new Promise((resolve, reject) => {
        zip.createWriter(new zip.BlobWriter(), resolve, reject, true);
    });

    return {
        add(fileName, content) {
            return new Promise(resolve => writer.add(fileName, new zip.BlobReader(content), resolve));
        },
        close() {
            return new Promise(resolve => writer.close(resolve));
        }
    }
}
