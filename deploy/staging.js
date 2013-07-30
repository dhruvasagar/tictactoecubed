var staging =   {
  name: "tictactoecubed",
  hosts : [{host: "tictactoecubed", location:"~/tictactoecubed"}],
  repository: { type: "git", url: "git@github.com:dhruvasagar/tictactoecubed.git", branch: "master"},
  deploymentType: { type: "npm" , env:{ NODE_ENV: "production"}, outputFile: "hat.js.log"},
  postdeploy: function cleanup (done) {
    console.log("Post deploy");
    this.cleanup(done);
    this._ssh("tictactoecubed.com", "forever restart -c coffee app.coffee");
  }
};
module.exports = staging;
