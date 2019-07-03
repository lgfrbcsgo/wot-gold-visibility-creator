export function cache<T>(fn: () => Promise<T>): () => Promise<T> {
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

export async function loadImageData(url: string): Promise<ImageData> {
    const image = await loadImage(url);
    const canvas = document.createElement('canvas') as HTMLCanvasElement;
    canvas.height = image.height;
    canvas.width = image.width;
    // cast to CanvasRenderingContext2D as getContext is guaranteed to not be null on a newly created Canvas
    const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
    ctx.drawImage(image, 0, 0);
    return ctx.getImageData(0, 0, image.width, image.height);
}

async function loadImage(url: string): Promise<HTMLImageElement | ImageBitmap> {
    const image = new Image();
    image.src = url;
    image.decoding = 'async';

    const loading = new Promise<HTMLImageElement>((resolve, reject) => {
        image.onload = () => resolve(image);
        image.onerror = () => reject();
    });

    if (image.decode) {
        // decode image data off the main thread in Chrome and Safari
        await image.decode();
    }

    if (self.createImageBitmap) {
        // decode image data off the main thread in Firefox
        return await self.createImageBitmap(await loading);
    } else {
        return await loading;
    }
}
