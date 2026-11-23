import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let arguments = CommandLine.arguments
let flags = Set(arguments.dropFirst(3))
let compactDojoSun = flags.contains("--compact-dojo-sun")
let roseDojoSky = flags.contains("--rose-dojo-sky")
guard arguments.count >= 3 && flags.isSubset(of: ["--compact-dojo-sun", "--rose-dojo-sky"]) else {
    fatalError("Usage: swift project_sunset.swift panorama.png output-directory [--compact-dojo-sun] [--rose-dojo-sky]")
}
let panorama = URL(fileURLWithPath: arguments[1])
let output = URL(fileURLWithPath: arguments[2], isDirectory: true)
let rgb = CGColorSpace(name: CGColorSpace.sRGB)!
let pixelFormat = CGImageAlphaInfo.premultipliedLast.rawValue
guard let source = CGImageSourceCreateWithURL(panorama as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      let bitmap = CGContext(data: nil, width: image.width, height: image.height,
          bitsPerComponent: 8, bytesPerRow: image.width * 4, space: rgb, bitmapInfo: pixelFormat) else {
    fatalError("Cannot read \(panorama.path)")
}
let width = image.width
let height = image.height
bitmap.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
let pixels = bitmap.data!.assumingMemoryBound(to: UInt8.self)
let faceSize = 512
// Side filenames follow the view from inside the cube: Right goes to SkyboxLf.
// Studio's texture coordinates join Up's top and Down's bottom to that +X side.
// Match that runtime orientation so clouds and gradients continue across each edge.
let faces: [(String, (Double, Double) -> (Double, Double, Double))] = [
    ("Front", { ( $0, $1, -1) }),
    ("Right", { (  1, $1, $0) }),
    ("Back",  { (-$0, $1,  1) }),
    ("Left",  { ( -1, $1,-$0) }),
    ("Up",    { ( $1,  1,-$0) }),
    ("Down",  { (-$1, -1,-$0) }),
]

func sample(_ column: Double, _ row: Double, _ channel: Int) -> Double {
    let x0 = Int(floor(column))
    let y0 = min(height - 1, max(0, Int(floor(row))))
    let y1 = min(height - 1, y0 + 1)
    let fx = column - floor(column)
    let fy = row - floor(row)
    let a = (x0 + width) % width
    let b = (a + 1) % width
    let upper = Double(pixels[(y0 * width + a) * 4 + channel]) * (1 - fx)
        + Double(pixels[(y0 * width + b) * 4 + channel]) * fx
    let lower = Double(pixels[(y1 * width + a) * 4 + channel]) * (1 - fx)
        + Double(pixels[(y1 * width + b) * 4 + channel]) * fx
    return upper * (1 - fy) + lower * fy
}

// Keep the source painting intact. This optional pass changes only a small
// patch around its original sun, before projecting the panorama to cube faces.
if compactDojoSun {
    guard width == 1774, height == 887 else {
        fatalError("The compact sun adjustment expects the original Beast Dojo panorama.")
    }
    let sunX = 1082.64
    let sunY = 408.65
    let radiusX = 27.6
    let radiusY = 25.0
    let diskScale = 0.40
    let repairRadius = 1.35
    let halo: [[Double]] = [
        [253.6455, -0.0146, 0.0190,   0.0049,  0.0677,  -0.0087],
        [240.7759,  0.7146, 2.4282, -13.7019,  0.1409, -17.5794],
        [143.3596,  0.4946, -7.7104, -13.9309, -0.1106, -15.3019],
    ]

    // Quadratic fit to the surrounding halo, sampled between radii 1.08–1.38
    // in the coordinates of the original elliptical disk.
    func haloValue(_ x: Double, _ y: Double, _ channel: Int) -> Double {
        let c = halo[channel]
        return c[0] + c[1] * x + c[2] * y + c[3] * x * x + c[4] * x * y + c[5] * y * y
    }

    func smoothEdge(_ value: Double, _ inner: Double, _ outer: Double) -> Double {
        let t = min(1, max(0, (value - inner) / (outer - inner)))
        return 1 - t * t * (3 - 2 * t)
    }

    var repaired: [(offset: Int, value: UInt8)] = []
    for row in Int(floor(sunY - radiusY * repairRadius))...Int(ceil(sunY + radiusY * repairRadius)) {
        for column in Int(floor(sunX - radiusX * repairRadius))...Int(ceil(sunX + radiusX * repairRadius)) {
            let x = (Double(column) - sunX) / radiusX
            let y = (Double(row) - sunY) / radiusY
            let distance = hypot(x, y)
            guard distance < repairRadius else { continue }
            let repair = smoothEdge(distance, 1.075, repairRadius)
            let disk = smoothEdge(distance / diskScale, 0.99, 1.10)

            for channel in 0..<3 {
                let offset = (row * width + column) * 4 + channel
                let original = Double(pixels[offset])
                let background = original + (haloValue(x, y, channel) - original) * repair
                var value = background
                if disk > 0 {
                    let diskX = x / diskScale
                    let diskY = y / diskScale
                    let source = sample(sunX + diskX * radiusX, sunY + diskY * radiusY, channel)
                    value += max(0, source - haloValue(diskX, diskY, channel)) * disk
                }
                repaired.append((offset, UInt8(clamping: Int(value.rounded()))))
            }
        }
    }
    for (offset, value) in repaired {
        pixels[offset] = value
    }
}

try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for (name, direction) in faces {
    let face = CGContext(data: nil, width: faceSize, height: faceSize, bitsPerComponent: 8,
        bytesPerRow: faceSize * 4, space: rgb, bitmapInfo: pixelFormat)!
    let target = face.data!.assumingMemoryBound(to: UInt8.self)
    for row in 0..<faceSize {
        for column in 0..<faceSize {
            let u = 2 * Double(column) / Double(faceSize - 1) - 1
            let v = 1 - 2 * Double(row) / Double(faceSize - 1)
            let (x, y, z) = direction(u, v)
            let azimuth = atan2(x, -z)
            let elevation = atan2(y, hypot(x, z)) - 7 * Double.pi / 180
            let horizontal = azimuth / (2 * .pi) + 0.555
            let columnInTexture = (horizontal - floor(horizontal)) * Double(width)
            let vertical = max(0, min(1, 0.5 - elevation / .pi)) * Double(height - 1)
            let seamWidth = Double(width) * 0.024
            let seamDistance = min(columnInTexture, Double(width) - columnInTexture)
            let mix = max(0, 1 - seamDistance / seamWidth)
            let offset = (row * faceSize + column) * 4
            for channel in 0..<3 {
                let normal = sample(columnInTexture, vertical, channel)
                let seam = sample(-0.5, vertical, channel)
                target[offset + channel] = UInt8(clamping: Int((normal + (seam - normal) * mix).rounded()))
            }
            target[offset + 3] = 255
        }
    }
    if roseDojoSky && name == "Front" {
        func smooth(_ value: Double, _ low: Double, _ high: Double) -> Double {
            let t = min(1, max(0, (value - low) / (high - low)))
            return t * t * (3 - 2 * t)
        }

        for row in 0..<faceSize {
            let elevation = 1 - 2 * Double(row) / Double(faceSize - 1)
            for column in 0..<faceSize {
                let azimuth = 2 * Double(column) / Double(faceSize - 1) - 1
                let center = 0.59 - 0.045 * azimuth
                let verticalReach = elevation > center ? 0.21 : 0.33
                let distance = hypot(azimuth / 0.84, (elevation - center) / verticalReach)
                guard distance < 1 else { continue }
                let weight = exp(-0.92 * distance * distance) * (1 - smooth(distance, 0.58, 1))
                let offset = (row * faceSize + column) * 4
                let warm = Double(target[offset + 1]) - Double(target[offset + 2])
                // Let the gold cloud highlights keep most of their original color.
                let mix = weight * (1 - 0.75 * smooth(warm, 31, 83))
                for (channel, delta) in [(-10.0), 13, 58].enumerated() {
                    let value = Double(target[offset + channel]) + delta * mix
                    target[offset + channel] = UInt8(clamping: Int(value.rounded()))
                }
            }
        }
    }
    let path = output.appendingPathComponent("Beast_Dojo_Sunset_\(name).png")
    let writer = CGImageDestinationCreateWithURL(path as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(writer, face.makeImage()!, nil)
    guard CGImageDestinationFinalize(writer) else { fatalError("Cannot write \(path.path)") }
}
