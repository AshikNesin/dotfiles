const CSVToJSON = require("csvtojson");

const readJsonFromCsvFile = async (csvPath) => {
  return CSVToJSON().fromFile(csvPath);
};

module.exports = readJsonFromCsvFile;
