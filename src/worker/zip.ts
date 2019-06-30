// @ts-ignore
import { zip } from '../../lib/zip.js/WebContent/zip.js';
// @ts-ignore
import zipWorkerPath from 'file-loader!../../lib/zip.js/WebContent/z-worker.js'

zip.workerScripts = {
    deflater: [zipWorkerPath]
};
