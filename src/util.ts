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

export function rethrow<T, U extends Array<T>, R>(fn: (...args: U) => Promise<R>): (...args: U) => Promise<R> {
    return (...args: U) => fn(...args)
        .catch(e => {
            setTimeout(() => {
                throw e
            });
            throw e;
        });
}