const converter = require("json-2-csv");
const fs = require("fs");

const writeJsonToCsvFile = async (json, csvPath) => {
  try {
    const csv = await converter.json2csvAsync(json);

    // print CSV string
    // console.log(csv);

    // write CSV to a file
    fs.writeFileSync(csvPath, csv);
  } catch (err) {
    console.log(err);
  }
};

module.exports = writeJsonToCsvFile;
