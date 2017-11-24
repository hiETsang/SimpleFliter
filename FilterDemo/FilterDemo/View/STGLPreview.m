//
//  STGLPreview.m
//
//  Created by sluin on 2017/1/11.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "STGLPreview.h"

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@interface STGLPreview ()
{
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth, backingHeight;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;

    GLuint positionRenderTexture;
    GLuint positionRenderbuffer, positionFramebuffer;
    
    GLuint stDisplayProgram;
    
    int uniformLocation;

}

@end

@implementation STGLPreview

// Override the class method to return the OpenGL layer, as opposed to the normal CALayer
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Do OpenGL Core Animation layer setup
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        _glContext = context;
        
        if (!_glContext) {
            
            return nil;
        }
        
        if ([EAGLContext currentContext] != _glContext) {
            
            if (![EAGLContext setCurrentContext:_glContext]) {
                
                return nil;
            }
        }
        
        if (![self createFramebuffers]) {
            
            return nil;
        }
        
        [self loadVertexShader:@"STDisplayShader"
                fragmentShader:@"STDisplayShader"
                    forProgram:&stDisplayProgram];
    }
    return self;
}

- (void)dealloc
{
    [self destroyFramebuffer];
}

- (BOOL)createFramebuffers
{
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);
    
    // Onscreen framebuffer object
    glGenFramebuffers(1, &viewFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    glGenRenderbuffers(1, &viewRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        
        NSLog(@"STGLPreview : failure with framebuffer generation");
        
        return NO;
    }
    
    // Offscreen position framebuffer object
    glGenFramebuffers(1, &positionFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, positionFramebuffer);
    
    glGenRenderbuffers(1, &positionRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, positionRenderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, (GLsizei)self.frame.size.width, (GLsizei)self.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, positionRenderbuffer);
    
    
    // Offscreen position framebuffer texture target
    glGenTextures(1, &positionRenderTexture);
    glBindTexture(GL_TEXTURE_2D, positionRenderTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)self.frame.size.width, (GLsizei)self.frame.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, positionRenderTexture, 0);
    
    return YES;
}

- (void)destroyFramebuffer;
{
    if (viewFramebuffer) {
        
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    
    if (viewRenderbuffer) {
        
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
}


- (BOOL)loadVertexShader:(NSString *)vertexShaderName
          fragmentShader:(NSString *)fragmentShaderName
              forProgram:(GLuint *)programPointer;
{
    GLuint vertexShader, fragShader;
    
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    *programPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShaderName ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER shaderString:vsh]) {
        
        NSLog(@"STGLPreview : failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER shaderString:fsh]) {
        
        NSLog(@"STGLPreview : failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*programPointer, vertexShader);
    
    // Attach fragment shader to program.
    glAttachShader(*programPointer, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*programPointer, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*programPointer, ATTRIB_TEXTUREPOSITON, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:*programPointer]) {
        
        NSLog(@"STGLPreview : failed to link program: %d", *programPointer);
        
        if (vertexShader) {
            
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragShader) {
            
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*programPointer) {
            
            glDeleteProgram(*programPointer);
            *programPointer = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniformLocation = glGetUniformLocation(*programPointer, "videoFrame");
    
    // Release vertex and fragment shaders.
    if (vertexShader) {
     
        glDeleteShader(vertexShader);
    }
    if (fragShader) {
        
        glDeleteShader(fragShader);
    }
    
    return YES;
}

char vsh[] = "attribute vec4 position;\
attribute vec4 inputTextureCoordinate;\
varying vec2 textureCoordinate;\
void main()\
{\
gl_Position = position;\
textureCoordinate = inputTextureCoordinate.xy;\
}";

char fsh[] = "varying highp vec2 textureCoordinate;\
uniform sampler2D videoFrame;\
void main()\
{\
gl_FragColor = texture2D(videoFrame, textureCoordinate);\
}";

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type shaderString:(char *)str
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)str;
    if (!source) {
        
        NSLog(@"STGLPreview : failed to load vertex shader");
        
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    
    if (0 == status) {
        
        return NO;
    }else{
        
        return YES;
    }
}

- (void)renderTexture:(GLuint)texture
{
    if ([EAGLContext setCurrentContext:self.glContext]) {
        
        [self drawFrameWithTexture:texture];
    }
}

- (BOOL)drawFrameWithTexture:(GLuint)texture
{
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    // Use shader program.
    if (!viewFramebuffer) {
        
        [self createFramebuffers];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
    glUseProgram(stDisplayProgram);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // Update uniform values
    glUniform1i(uniformLocation, 0);
    
    // Update attribute values.
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    BOOL isSuccess = NO;
    
    if (_glContext) {
        
        glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
        isSuccess = [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return isSuccess;
}



@end
