'use strict';

const EE = require('eventemitter3'),
    _ = require('lodash');

module.exports = function () {
    const events = new EE(),
        makePassFailRollup = function (nodes) {
            return {
                count: nodes.length,
                passes: _.filter(nodes, node => node.passed).length
            };
        },
        dumpLogs = function (node) {
            const rollup = _.isArray(node.children)
                    ? makePassFailRollup(node.children)
                    : {},
                eventData = _.chain(node)
                    .omit('children')
                    .merge(rollup)
                    .value();

            events.emit(node.summaryFor, eventData);
            if (node.children) {
                node.children.forEach(dumpLogs);
            }
            events.emit(`AFTER-${node.summaryFor}`, eventData);
        };

    return _.merge(events, {
        readLog: logFile => {
            const logData = require(logFile);

            dumpLogs(logData);
        }
    });
};
