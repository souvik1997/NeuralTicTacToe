module.exports = function(grunt) {

  grunt.initConfig({
    jshint: {
      files: ['Gruntfile.js', 'src/**/*.js', 'test/**/*.js'],
      options: {
        globals: {
          jQuery: true
        }
      }
    },
    coffeelint: {
      app: ['*.coffee', 'src/**/*.coffee'],
      tests: ['tests/**/*.coffee']
    },
    watch: {
      js: {
        files: ['<%= jshint.files %>'],
        tasks: ['jshint']
      },
      coffeescript: {
        files: ['<%= coffeelint.files %>'],
        tasks: ['coffeelint']
      }
    },
    karma: {
      unit: {
        options: {
          files: ['src/**/*.coffee', 'tests/**/*.coffee'],
          preprocessors: {'**/*.coffee': ['coffee'] },
          frameworks: ['jasmine'],
          reporters: ['progress'],
          port: 9876,
          colors: true,
          autoWatch: true,
          browsers: ['Chrome', 'PhantomJS']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-karma');


  grunt.registerTask('default', ['jshint', 'coffeelint']);

};