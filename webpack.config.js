const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WasmPackPlugin = require('@wasm-tool/wasm-pack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const WorkerPlugin = require('worker-plugin');

const dist = path.resolve(__dirname, 'dist');

module.exports = {
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
                    { loader: 'elm-hot-webpack-loader' },
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            cwd: __dirname,
                            optimize: true
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
                test: /\.png$/,
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '[hash].[ext]'
                        },
                    },
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
        new HtmlWebpackPlugin({
            filename: 'error.html',
            template: 'src/error.html',
            inject: false
        }),
        new WasmPackPlugin({
            crateDirectory: path.resolve(__dirname, 'src/worker/wasm'),
            forceMode: 'production'
        }),
        new WorkerPlugin({
            globalObject: 'self'
        })
    ]
};
