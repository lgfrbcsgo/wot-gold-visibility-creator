import {Color} from "../worker/types";

export namespace Elm {
    namespace Main {
        export interface App {
            ports: {
                run: {
                    subscribe(callback: (color: Color) => void): void
                }
            };
        }
        export function init(options: {
            node: HTMLElement | null;
            flags?: null;
        }): Elm.Main.App;
    }
}