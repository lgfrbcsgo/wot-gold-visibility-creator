const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WasmPackPlugin = require('@wasm-tool/wasm-pack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const WorkerPlugin = require('worker-plugin');

const tailwindcss = require('tailwindcss');
const purgecss = require('@fullhuman/postcss-purgecss');
const cssnano = require('cssnano');
const autoprefixer = require('autoprefixer');


const project = __dirname;
const dist = path.resolve(project, 'dist');
const wasm = path.resolve(project, 'src/worker/wasm');

const createConfig = (inProdMode, inDevMode) => ({
    entry: './src/index.ts',
    ...inDevMode({
        mode: 'development'
    }),
    ...inProdMode({
        mode: 'production'
    }),
    output: {
        path: dist,
        filename: '[name].[hash].js',
        globalObject: 'self'
    },
    resolve: {
        extensions: ['.ts', '.js', '.wasm', '.json', '.elm']
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    { loader: 'elm-css-modules-loader' },
                    { loader: 'elm-hot-webpack-loader' },
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            cwd: project,
                            ...inDevMode({
                                debug: true
                            }),
                            ...inProdMode({
                                optimize: true
                            })
                        }
                    }
                ]
            },
            {
                test: /\.ts$/,
                use: 'ts-loader',
                exclude: /node_modules/
            },
            {
                test: /\.css$/,
                use: [
                    { loader:  'style-loader' },
                    {
                        loader: 'css-loader',
                        options: {
                            modules: true,
                            importLoaders: 1
                        }
                    },
                    {
                        loader: 'postcss-loader',
                        options: {
                            ident: 'postcss',
                            plugins: [
                                tailwindcss(),
                                purgecss({
                                    content: [
                                        './src/**/*.elm',
                                        './src/**/*.ts'
                                    ],
                                }),
                                ...inProdMode([
                                    cssnano({
                                        preset: 'default',
                                    }),
                                    autoprefixer
                                ])
                            ]
                        }
                    }
                ]
            },
            {
                test: /\.(png|svg)$/,
                use: [
                    {
                        loader: 'url-loader',
                        options: {
                            limit: 8192,
                            fallback: 'file-loader',
                            name: '[hash].[ext]'
                        }
                    }
                ],
            }
        ]
    },
    devServer: {
        contentBase: dist,
    },
    plugins: [
        new CleanWebpackPlugin(),
        new HtmlWebpackPlugin({
            filename: 'index.html',
            template: 'src/index.html'
        }),
        new WasmPackPlugin({
            crateDirectory: wasm,
            forceMode: 'production'
        }),
        new WorkerPlugin({
            globalObject: 'self'
        })
    ]
});

module.exports = (production = true) => createConfig(inProdMode(production), inDevMode(production));

function inProdMode(production) {
    return arrayOrObject => {
        if (production) {
            return arrayOrObject;
        } else {
            return Array.isArray(arrayOrObject) ? [] : {};
        }
    }
}

function inDevMode(isProd) {
    return inProdMode(!isProd);
}