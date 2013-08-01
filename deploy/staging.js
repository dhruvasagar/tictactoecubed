var staging =   {
  name: "tictactoecubed",
  hosts : [{host: "tictactoecubed", location:"~/tictactoecubed"}],
  repository: { type: "git", url: "git@github.com:dhruvasagar/tictactoecubed.git", branch: "master"},
  deploymentType: { type: "npm" , env:{ NODE_ENV: "production"}, outputFile: "hat.js.log"},
  predeploy: function(cb) {
    var self = this;
    console.log('Stopping forever');
    this.hosts(function(host, done) {
      self._ssh(host, [
        "cd " + self.deploymentOptions.currentPath(host),
        "forever stop -c coffee app.coffee"
      ], done);
    }, cb);
  },
  postchangeSymlinks: function(cb) {
    var self = this;
    this.hosts(function(host, done) {
      self._ssh(host, [
        "ln -s " + self.deploymentOptions.sharedPath(host) + "config/config.json " +
        self.deploymentOptions.newReleasePath(host) + "config/config.json"
      ], done);
    }, cb);
  },
  postdeploy: function(cb) {
    var self = this;
    console.log('Stopping forever');
    this.hosts(function(host, done) {
      self._ssh(host, [
        "cd " + self.deploymentOptions.currentPath(host),
        "forever start -c coffee app.coffee"
      ], done);
    }, cb);
  }
};
module.exports = staging;
