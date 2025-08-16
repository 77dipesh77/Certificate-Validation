// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificateValidation {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        string ipfsHash;  
        uint64 issuedAt;
        bool isRevoked;
        uint64 revokedAt;
    }

    // certId => Certificate
    mapping(uint256 => Certificate) public certificates;

    event CertificateIssued(
        uint256 indexed certId,
        string studentName,
        string courseName,
        string ipfsHash,
        uint64 issuedAt
    );
    event CertificateRevoked(uint256 indexed certId, uint64 revokedAt);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Issue a new certificate (only the owner/admin can do this)
    function issueCertificate(
        uint256 certId,
        string calldata studentName,
        string calldata courseName,
        string calldata ipfsHash
    ) external onlyOwner {
        // prevent overwriting an existing cert
        require(bytes(certificates[certId].studentName).length == 0, "ALREADY_EXISTS");

        certificates[certId] = Certificate({
            studentName: studentName,
            courseName: courseName,
            ipfsHash: ipfsHash,
            issuedAt: uint64(block.timestamp),
            isRevoked: false,
            revokedAt: 0
        });

        emit CertificateIssued(certId, studentName, courseName, ipfsHash, uint64(block.timestamp));
    }

    // Revoke an existing certificate (only owner)
    function revokeCertificate(uint256 certId) external onlyOwner {
        Certificate storage c = certificates[certId];
        require(bytes(c.studentName).length != 0, "NOT_FOUND");
        require(!c.isRevoked, "ALREADY_REVOKED");

        c.isRevoked = true;
        c.revokedAt = uint64(block.timestamp);

        emit CertificateRevoked(certId, c.revokedAt);
    }

    // Anyone can verify: returns all key fields
    function verifyCertificate(uint256 certId)
        external
        view
        returns (
            string memory studentName,
            string memory courseName,
            string memory ipfsHash,
            uint64 issuedAt,
            bool isRevoked,
            uint64 revokedAt
        )
    {
        Certificate memory c = certificates[certId];
        require(bytes(c.studentName).length != 0, "NOT_FOUND");
        return (c.studentName, c.courseName, c.ipfsHash, c.issuedAt, c.isRevoked, c.revokedAt);
    }
}
