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

const createConfig = (inProd, inDev) => ({
    entry: './src/index.ts',
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
                            ...inDev({
                                debug: true
                            }),
                            ...inProd({
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
                                ...inProd([
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

// supply default for argv for Webstorm to be able to analyze the config
module.exports = (env, argv = {p: true}) => createConfig(inProd(argv.p), inDev(argv.p));

function inProd(isProd) {
    return arrayOrObject => {
        if (isProd) {
            return arrayOrObject;
        } else {
            return Array.isArray(arrayOrObject) ? [] : {};
        }
    }
}

function inDev(isProd) {
    return inProd(!isProd);
}