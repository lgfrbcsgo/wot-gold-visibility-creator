import {Rgba} from "../types";

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
                startWorker: PortFromElm<Rgba>,
                finishedModPackage: PortToElm<void>
            };
        }
        export function init(options: {
            node: HTMLElement | null;
            flags?: null;
        }): Elm.Main.App;
    }
}