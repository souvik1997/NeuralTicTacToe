module.exports = function(grunt) {

  grunt.initConfig({
    jshint: {
      files: ['Gruntfile.js', 'src/**/*.js'],
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
      tests: {
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
          'dist/js/module.js': ['tmp/js/**/*.js'],
        }
      }
    },
    clean: {
      build: ['dist/'],
      tmp: ['tmp/'],
    },
    jasmine: {
      src: ['dist/js/module.js']
    },
    uglify: {
      release:
      {
        files:
        {
          'dist/js/module.js': ['dist/js/module.js']
        }
      }
    },
    uncss: {
      release:
      {
        files:
        {
          'dist/css/module.css': ['dist/index.html']
        }
      }
    },
    cssmin: {
      release:
      {
        files:
        {
          'dist/css/module.css': ['node_modules/bootstrap/dist/**/*.css','!node_modules/bootstrap/dist/**/*.min.css', 'node_modules/vis/dist/**/*.css', '!node_modules/vis/dist/**/min.css', 'styles/**/*.css']
        }
      },
      recssmin:
      {
        files:
        {
          'dist/css/module.css': ['dist/css/module.css']
        }
      }
    },
    copy: {
      html: {
        flatten: true,
        expand: true,
        src: 'html/**/*.html',
        dest: 'dist/'
      },
      js: {
        flatten: true,
        expand: true,
        src: 'src/**/*.js',
        dest: 'tmp/js/'
      },
      bootstrapfonts: {
        flatten: true,
        expand: true,
        src: 'node_modules/bootstrap/dist/fonts/*',
        dest: 'dist/fonts/'
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
  grunt.loadNpmTasks('grunt-uncss');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-copy');


  grunt.registerTask('default', ['clean:build', 'clean:tmp', 'jshint', 'coffeelint', 'cssmin:release', 'copy:html', 'copy:bootstrapfonts', 'copy:js', 'coffee:app']);
  grunt.registerTask('debug', ['default', 'coffee:tests', 'browserify', 'jasmine']);
  grunt.registerTask('release', ['default', 'browserify', 'uglify', 'uncss:release', 'cssmin:recssmin']);

};