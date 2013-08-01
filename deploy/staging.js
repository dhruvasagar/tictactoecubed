var staging =   {
  name: "tictactoecubed",
  hosts : [{host: "tictactoecubed", location:"~/tictactoecubed"}],
  repository: { type: "git", url: "git@github.com:dhruvasagar/tictactoecubed.git", branch: "master"},
  deploymentType: { type: "npm" , env:{ NODE_ENV: "production"}, outputFile: "hat.js.log"},
  postsetup: function(cb) {
    var self = this;
    console.log('shutting down forever before checkout');
    this.hosts(function(host, done) {
      self._ssh(host, [
        "cd " + self.deploymentOptions.releasesPath(host),
        "forever stop -c coffee app.coffee"
      ], done);
    }, cb);
  },
  restart: function(cb) {
    var self = this;
    console.log('Restarting forever');
    this.hosts(function(host, done) {
      self._ssh(host, [
        "cd " + self.deploymentOptions.currentPath(host),
        "forever start -c coffee app.coffee"
      ], done);
    }, cb);
  }
};
module.exports = staging;
