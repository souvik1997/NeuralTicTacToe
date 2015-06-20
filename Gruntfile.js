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
          files: ['dist/module.js', 'dist/module.tests.js'],
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
        dest: 'dist/',
        ext: '.js'
      },
      test: {
        expand: true,
        flatten: true,
        src: ['tests/*.coffee'],
        dest: 'dist/tests/',
        ext: '.test.js'
      }
    },
    browserify: {
      app: {
        files: {
          'dist/module.js': ['dist/*.js'],
        }
      },
      test: {
        files: {
          'dist/module.tests.js': ['dist/tests/*.js']
        },
      }
    },
    clean: {
      build: ['dist/']
    },
    jasmine: {
      src: ['dist/module.js', 'dist/module.tests.js']
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


  grunt.registerTask('default', ['jshint', 'coffeelint', 'test']);
  grunt.registerTask('test', ['clean:build', 'coffee:app', 'coffee:test', 'browserify:app', 'browserify:test', 'jasmine']);

};