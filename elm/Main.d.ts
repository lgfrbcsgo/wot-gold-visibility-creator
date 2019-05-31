import {ColorOptions} from "../worker/util/types";

export namespace Elm {
    namespace Main {
        export interface App {
            ports: {
                run: {
                    subscribe(callback: (color: ColorOptions) => void): void
                }
            };
        }
        export function init(options: {
            node: HTMLElement | null;
            flags?: null;
        }): Elm.Main.App;
    }
}