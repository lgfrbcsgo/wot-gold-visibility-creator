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

export type LazyPromise<T> = () => Promise<T>;

export function cache<T>(fn: LazyPromise<T>): LazyPromise<T> {
    let cachedPromise: Promise<T> | null;

    return async () => {
        cachedPromise = cachedPromise || fn();
        try {
            return await cachedPromise;
        } catch (e) {
            cachedPromise = null;
            throw e;
        }
    }
}

export async function* limitConcurrency<T>(
    concurrencyLevel: number, promises: Array<LazyPromise<T>>
): AsyncIterableIterator<T> {

    const racingPromises: Array<Promise<T>> = [];

    const activate = (lazyPromise: LazyPromise<T>) => racingPromises.push(lazyPromise());

    const zipIndex = async (promise: Promise<T>, index: number) => ({
        index,
        result: await promise
    });

    const race = async () => {
        const {result, index} = await Promise.race(
            racingPromises.map(zipIndex)
        );
        racingPromises.splice(index, 1);
        return result;
    };

    for (const lazyPromise of promises.slice(0, concurrencyLevel)) {
        activate(lazyPromise);
    }
    for (const lazyPromise of promises.slice(concurrencyLevel)) {
        yield await race();
        activate(lazyPromise);
    }
    while (racingPromises.length) {
        yield await race();
    }
}
