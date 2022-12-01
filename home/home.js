const http = require("http");
const express = require('express');
const app = express();
const path = require('path');

app.get('/free', (req, res) => {
  var resp = {};
  var options = {
        host: 'price',
        port: 3010,
        path: '/free',
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    var remote_req = http.request(options, function(remote_res)
    {
        remote_res.setEncoding('utf8');
        remote_res.on('data', function (data) {
            resp = data;
            res.send(resp);
        });
    });
    remote_req.end();
});

app.get('/pro', (req, res) => {
  var resp = {};
  var options = {
        host: 'price',
        port: 3010,
        path: '/pro',
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    var remote_req = http.request(options, function(remote_res)
    {
        remote_res.setEncoding('utf8');
        remote_res.on('data', function (data) {
            resp = data;
            res.send(resp);
        });
    });
    remote_req.end();
});

app.get('/enterprise', (req, res) => {
  var resp = {};
  var options = {
        host: 'price',
        port: 3010,
        path: '/enterprise',
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    var remote_req = http.request(options, function(remote_res)
    {
        remote_res.setEncoding('utf8');
        remote_res.on('data', function (data) {
            resp = data;
            res.send(resp);
        });
    });
    remote_req.end();
});

app.use('/', express.static(path.join(__dirname, 'html/pricing')));

app.listen(3000);

