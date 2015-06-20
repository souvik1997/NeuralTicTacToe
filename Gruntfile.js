module.exports = function(grunt) {

  grunt.initConfig({
    jshint: {
      files: ['Gruntfile.js', 'src/**/*.js'],
      options: {
        globals: {
          jQuery: true
        }
      }
    },
    coffeelint: {
      app: ['*.coffee', 'src/**/*.coffee'],
    },
    watch: {
      app: {
        files: ['src/**/*.js', 'src/**/*.coffee'],
        tasks: ['default']
      },
    },
    karma: {
      unit: {
        options: {
          files: ['dist/js/module.js', 'dist/js/module.tests.js'],
          frameworks: ['jasmine', 'browserify'],
          reporters: ['progress'],
          port: 9876,
          colors: true,
          autoWatch: false,
          browsers: ['Chrome', 'PhantomJS'],
          browserify: {
            debug: true,
            transform: [ 'coffeeify' ]
          }
        }
      }
    },
    coffee: {
      app: {
        expand: true,
        flatten: true,
        src: ['src/*.coffee'],
        dest: 'tmp/js/',
        ext: '.js'
      },
      test: {
        expand: true,
        flatten: true,
        src: ['src/tests/*.coffee'],
        dest: 'tmp/js/tests/',
        ext: '.test.js'
      }
    },
    browserify: {
      app: {
        files: {
          'dist/js/module.js': ['tmp/js/*.js'],
        }
      },
      test: {
        files: {
          'dist/js/module.tests.js': ['tmp/js/tests/*.js']
        },
      }
    },
    clean: {
      build: ['dist/'],
      tmp: ['tmp/'],
      post_testbuild: ['dist/js/module.js'],
      post_releasebuild: ['dist/js/module.js', 'dist/js/module.tests.js']
    },
    jasmine: {
      src: ['dist/js/module.tests.js']
    },
    uglify: {
      release:
      {
        files:
        {
          'dist/js/module.min.js': ['dist/js/module.js']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-uglify');


  grunt.registerTask('default', ['jshint', 'coffeelint', 'build']);
  grunt.registerTask('build', ['clean:build', 'clean:tmp', 'coffee:app', 'coffee:test', 'browserify:app', 'browserify:test', 'jasmine']);
  grunt.registerTask('test', ['default', 'clean:post_testbuild']);
  grunt.registerTask('release', ['default', 'uglify', 'clean:post_releasebuild']);

};