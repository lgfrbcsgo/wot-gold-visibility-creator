const {zip}: any = require('../../lib/zip.js/WebContent/zip.js');
const zipWorkerUrl: string = require('file-loader!../../lib/zip.js/WebContent/z-worker.js');

zip.workerScripts = {
    deflater: [zipWorkerUrl]
};

export interface ZipEntry {
    path: string;
    content: Blob;
}

export async function zipFile(files: AsyncIterableIterator<ZipEntry>): Promise<Blob> {
    const zipWriter = await createZipWriter();
    try {
        for await (const {path, content} of files) {
            await zipWriter.add(path, content);
        }
        return await zipWriter.close();
    } catch (e) {
        await zipWriter.close();
        throw e;
    }
}

async function createZipWriter() {
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