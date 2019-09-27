from scipy import signal
import numpy

def butter_bandpass(lowcut, highcut, fs, order=3):
     nyq = 0.5 * fs
     low = lowcut / nyq
     high = highcut / nyq
     b, a = signal.butter(order, [low, high], btype='band')
     return b, a


def butter_bandpass_filter(data, lowcut, highcut, fs, order=3):
    if data is None:
        return None

    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    n = data.shape[0]
    window = signal.tukey(n*3)
    #mirror extension of data by iteself on both ends
    data_ext = numpy.hstack([data[::-1], data, data[::-1]])
    y = signal.lfilter(b, a, data_ext*window)
    return y[n:2*n]
