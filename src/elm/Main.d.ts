import {ColorOptions} from "../worker/common";

interface PortToElm<T> {
    send(value: T) : void;
}

interface PortFromElm<T> {
    subscribe(callback: (value: T) => void): void
}

export namespace Elm {
    namespace Main {
        export interface App {
            ports: {
                runWorker: PortFromElm<ColorOptions>,
                revokeBlob: PortFromElm<string>,
                saveBlob: PortFromElm<{ blobUrl: string, fileName: string }>
                getPackage: PortToElm<{ color: ColorOptions, blobUrl: string }>
            };
        }
        export function init(options: {
            node: HTMLElement | null;
            flags?: null;
        }): Elm.Main.App;
    }
}