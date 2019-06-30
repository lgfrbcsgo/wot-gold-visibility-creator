// @ts-ignore
import { zip } from '../../lib/zip.js/WebContent/zip.js';
// @ts-ignore
import zipWorkerPath from 'file-loader!../../lib/zip.js/WebContent/z-worker.js'

zip.workerScripts = {
    deflater: [zipWorkerPath]
};


export async function createWriter() {
    const writer: any = await new Promise((resolve, reject) => {
        zip.createWriter(new zip.BlobWriter(), resolve, reject, true);
    });

    return {
        add(fileName: string, content: Blob): Promise<void> {
            return new Promise(resolve => writer.add(fileName, new zip.BlobReader(content), resolve));
        },
        close(): Promise<Blob> {
            return new Promise(resolve => writer.close(resolve));
        }
    }
}