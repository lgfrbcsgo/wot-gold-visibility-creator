export function saveBlob(blob: Blob, fileName: string) {
    if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, fileName);
    } else {
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

/**
 * Throws the error inside a setTimout to trigger the global error hook from the context of a Promise
 */
export function rethrowError(e: Error) {
    setTimeout(() => {
        throw e;
    });
    return Promise.reject(e);
}