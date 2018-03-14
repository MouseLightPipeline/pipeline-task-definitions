const path = require("path");
const fs = require("fs");

const project_name = process.argv.length > 2 ? process.argv[2] : null;
const project_root = process.argv.length > 3 ? process.argv[3] : null;
const pipeline_input_root = process.argv.length > 7 ? process.argv[4] : null;
const pipeline_output_root = process.argv.length > 5 ? process.argv[5] : null;
const tile_relative_path = process.argv.length > 6 ? process.argv[6] : null;
const tile_name = process.argv.length > 7 ? process.argv[7] : null;
const log_root_path = process.argv.length > 8 ? process.argv[8] : null;
const adjacent_relative_path = process.argv.length > 9 ? process.argv[9] : null;
const adjacent_tile_name = process.argv.length > 10 ? process.argv[10] : null;
const expected_exit_code = process.argv.length > 11 ? process.argv[11] : null;
const task_id = process.argv.length > 12 ? process.argv[12] : null;
const is_cluster_job = process.argv.length > 13 ? process.argv[13] : null;

fs.writeFileSync(path.join(pipeline_output_root, tile_relative_path, `${tile_name}.json`), JSON.stringify({
    project_name,
    project_root,
    pipeline_input_root,
    pipeline_output_root,
    tile_relative_path,
    tile_name,
    log_root_path,
    adjacent_relative_path,
    adjacent_tile_name,
    expected_exit_code,
    task_id,
    is_cluster_job
}, null, 4));
