/**
 * Utility functions to parse and format AGV communication messages.
 * Supports JSON and custom delimited string formats.
 */

/**
 * Parses a message string (JSON or delimited) into an object.
 * @param {string} message
 * @returns {Object}
 */
function parseMessage(message) {
    // Try JSON first
    try {
        return JSON.parse(message);
    } catch (e) {
        // Fallback: parse as key1=value1;key2=value2
        const obj = {};
        message.split(';').forEach(pair => {
            const [key, value] = pair.split('=');
            if (key && value !== undefined) {
                obj[key.trim()] = isNaN(value) ? value.trim() : Number(value);
            }
        });
        return obj;
    }
}

/**
 * Formats an object into a message string.
 * @param {Object} obj
 * @param {'json'|'delimited'} [format='json']
 * @returns {string}
 */
function formatMessage(obj, format = 'json') {
    if (format === 'json') {
        return JSON.stringify(obj);
    } else if (format === 'delimited') {
        return Object.entries(obj)
            .map(([k, v]) => `${k}=${v}`)
            .join(';');
    }
    throw new Error('Unsupported format');
}

module.exports = {
    parseMessage,
    formatMessage
};