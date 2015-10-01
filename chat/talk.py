#!/usr/bin/env python

import re
import subprocess
import exceptions
import traceback

from twisted.internet import protocol, reactor
from twisted.words.xish import domish
from twisted.words.xish.xmlstream import XmlStream
from twisted.words.protocols.jabber import jid
from wokkel.xmppim import Message

from twisted.words.protocols.jabber.xmpp_stringprep import nameprep
nameprep.prohibiteds = []

class ServerlessXMPPProtocol(XmlStream):

    namespace = None
    on_zone_pattern = "(?<=on)\s+(\w+)"
    off_zone_pattern = "(?<=off)\s+(\w+)"

    NAMESPACE = 'jabber:client'
    STREAM_NAMESPACE = 'http://etherx.jabber.org/streams'
    GPIO_CMD_PATH = "gpio"

    def __init__(self):
        XmlStream.__init__(self)
        self.commands = (('^hello', self.on_hello),
                         ('^help', self.on_help),
                         ('^turn on', self.on_turn_on),
                         ('^turn off', self.on_turn_off))

    def zone_state(self, zone, on):
        """
        Turn the zone on off.
        """
        gpio_pin = {'vegies':'23',
                    'garden' : '22',
                    'grass' : '17'}[zone]

        gpio_level = {True:'0', False:'1'}[on]
        subprocess.call([self.GPIO_CMD_PATH, "-g", "write",
                         gpio_pin,
                         gpio_level])


    def reply_message(self, message, body):
        """
        Reply to message with body.
        """
        response = Message(recipient=message.sender,
                           sender=message.recipient,
                           body=body)
        response.stanzaType = 'chat'
        self.send(response.toElement())


    def on_turn_on(self, message):

        results = re.findall(self.on_zone_pattern, message.body)
        zone = None
        if len(results) > 0:
            zone = results[0].lower()
        if zone:
            reply_body = "I've turned %s zone on." % zone
            try:
                self.zone_state(zone, True)
            except exceptions.OSError, e:
                traceback.print_exc()
                reply_body = "I was unable to turn on the %s zone." % zone
                reply_body += '\n%s' % traceback.format_exc()
        else:
            reply_body = "You didn't tell me which zone to turn on."
        self.reply_message(message, reply_body)


    def on_turn_off(self, message):

        results = re.findall(self.off_zone_pattern, message.body)
        zone = None
        if len(results) > 0:
            zone = results[0].lower()
        if zone:
            reply_body = "I've turned %s zone off." % zone
            try:
                self.zone_state(zone, False)
            except exceptions.OSError, e:
                traceback.print_exec()
                reply_body = "I was unable to turn on the %s zone." % zone
                reply_body += '\n%s' % traceback.format_exc()
        else:
            reply_body = "You didn't tell me which zone to turn off."
        self.reply_message(message, reply_body)


    def on_hello(self, message):
        response = Message(recipient=message.sender,
                           sender=message.recipient,
                           body="Hi I'm the backyard irrigation controller.")
        response.stanzaType = 'chat'
        self.send(response.toElement())


    def on_help(self, message):
        self.reply_message(message, "usage:")
        self.reply_message(message, "turn on <zone>")
        self.reply_message(message, "turn off <zone>")

    def handle_message(self, element):
        #print element.toXml()
        message = Message.fromElement(element)
        if message.stanzaType == 'chat':
#            print "From: %s To: %s\n%s" % (message.sender,
#                                           message.recipient,
#                                           message.body)
#
            # parse command
            for (pattern, handler) in self.commands:
                match = re.search(pattern, message.body)
                if match:
                    handler(message)


    def streamStarted(self, rootElement):
        """
        Got the start of the stream element.
        """

        self.namespace = rootElement.defaultUri
        if rootElement.hasAttribute("to"):
            self.thisEntity = jid.internJID(rootElement["to"])

        if rootElement.hasAttribute("from"):
            self.otherEntity = jid.internJID(rootElement["from"])

        self.prefixes = {}
        for prefix, uri in rootElement.localPrefixes.iteritems():
            self.prefixes[uri] = prefix

        self.sendHeader()


    def sendHeader(self):
        """
        Send stream header.
        """
        rootElement = domish.Element((self.STREAM_NAMESPACE, 'stream'),
                                     self.namespace)

        if self.otherEntity:
            rootElement['to'] = self.otherEntity.userhost()

        if self.thisEntity:
            rootElement['from'] = self.thisEntity.userhost()

        rootElement['version'] = "1.0"

        self.send(rootElement.toXml(prefixes=self.prefixes, closeElement=0))
        self._headerSent = True

    def onDocumentStart(self, rootElement):
        XmlStream.onDocumentStart(self, rootElement)
        self.streamStarted(rootElement)
        self.addObserver('/message[@xmlns="%s"]' % self.NAMESPACE, self.handle_message)


class ServerlessXMPPFactory(protocol.ServerFactory):

    protocol = ServerlessXMPPProtocol

reactor.listenTCP(7364, ServerlessXMPPFactory())
reactor.run()
