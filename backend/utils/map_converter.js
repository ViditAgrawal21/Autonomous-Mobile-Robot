/**
 * Utility functions to convert AGV map data between different formats.
 * Example: JSON <-> CSV, or custom AGV map format <-> standard format.
 */

const fs = require('fs');
const path = require('path');

/**
 * Converts a map object (JSON) to CSV format.
 * @param {Object[]} mapData - Array of map points or nodes.
 * @returns {string} CSV string.
 */
function mapToCSV(mapData) {
    if (!Array.isArray(mapData) || mapData.length === 0) return '';
    const headers = Object.keys(mapData[0]);
    const csvRows = [
        headers.join(','),
        ...mapData.map(row => headers.map(h => row[h]).join(','))
    ];
    return csvRows.join('\n');
}

/**
 * Converts a CSV string to a map object (JSON).
 * @param {string} csv - CSV string.
 * @returns {Object[]} Array of map points or nodes.
 */
function csvToMap(csv) {
    const [headerLine, ...lines] = csv.trim().split('\n');
    const headers = headerLine.split(',');
    return lines.map(line => {
        const values = line.split(',');
        const obj = {};
        headers.forEach((h, i) => {
            obj[h] = isNaN(values[i]) ? values[i] : Number(values[i]);
        });
        return obj;
    });
}

/**
 * Loads a map from a JSON file.
 * @param {string} filePath
 * @returns {Promise<Object[]>}
 */
function loadMapFromJson(filePath) {
    return new Promise((resolve, reject) => {
        fs.readFile(path.resolve(filePath), 'utf8', (err, data) => {
            if (err) return reject(err);
            try {
                const map = JSON.parse(data);
                resolve(map);
            } catch (e) {
                reject(e);
            }
        });
    });
}

/**
 * Saves a map object to a CSV file.
 * @param {Object[]} mapData
 * @param {string} filePath
 * @returns {Promise<void>}
 */
function saveMapToCsv(mapData, filePath) {
    return new Promise((resolve, reject) => {
        const csv = mapToCSV(mapData);
        fs.writeFile(path.resolve(filePath), csv, 'utf8', err => {
            if (err) return reject(err);
            resolve();
        });
    });
}

module.exports = {
    mapToCSV,
    csvToMap,
    loadMapFromJson,
    saveMapToCsv
};